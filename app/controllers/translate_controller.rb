class TranslateController < ActionController::Base
  # It seems users with active_record_store may get a "no :secret given" error if we don't disable csrf protection,
  skip_before_filter :verify_authenticity_token

  layout 'translate'

  def index
    @default_locale = @current_user.staff.locales.all(:order=>"locale_id").first
    conditions = ""
    conditions_args = []
    @locale =  params[:locale].present? ? params[:locale] : default_locale

    conditions = "1=1"

    if params[:key_pattern]
      conditions << " AND `key` like ?"
      conditions_args << "%#{params[:key_pattern]}%"
    end
    if params[:text_pattern] && !params[:text_pattern].empty?
      conditions << " AND value like ?"
      conditions_args << "%#{params[:text_pattern]}%"
    end

    if params[:empty_text_pattern] && !params[:empty_text_pattern].empty?
      conditions << " AND (value is NULL or value = '')"
    end

    @translations = Translation.paginate(:conditions => [conditions, *conditions_args],
      :order => "`key`",
      :per_page => 10,
      :page => params[:page])

  end


  #it will destroy all translations from given key
  def destroy
    Translation.delete_all(["`key` = ?", params[:key]])
    redirect_to :action => :index
  end

  def multiple_update
    locale = params[:locale]
    count = 0
    for key, value in params[:keys]
      translation = Translation.find_by_key_and_locale(key, locale)
      if translation.value != value
        translation.update_attribute(:value, value)
        count += 1
      end
    end
    flash[:notice] = "#{count} key updated."
    params.delete 'keys'
    params.delete 'commit'
    params['page'] = 1 if params['page'].blank?
    redirect_to params.merge :action => :index
  end

  def new
    @page_title = 'New key'
    @translation = Translation.new()
  end

  def create
    @translation = Translation.new(params[:translation])
    if @translation.save
      #create other translations
      for locale in Locale.find(:all, :condtions => ["id != ?", @translation.locale_id])
        t = Translation.new(params[:translation])
        t.locale_id = locale.id
        t.save
      end

      redirect_to :action => :index
    else
      render :new
    end
  end

  private

  def default_locale
    I18n.default_locale
  end
end
