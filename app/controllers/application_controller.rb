class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_ability

  protect_from_forgery with: :exception
  include ApplicationHelper

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    current_user.admin? ? redirect_to(rails_admin.dashboard_path) : redirect_to(main_app.root_path)
  end

  def after_sign_in_path_for resource
    sign_in_url = new_user_session_url
    if request.referer == sign_in_url
      current_user.admin? ? rails_admin.dashboard_path : root_path
    else
      stored_location_for(resource) || request.referer || root_path
    end
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push :name
    devise_parameter_sanitizer.for(:sign_up).push :chatwork_id
    devise_parameter_sanitizer.for(:account_update).push :name
    devise_parameter_sanitizer.for(:account_update).push :chatwork_id
    devise_parameter_sanitizer.for(:account_update).push :chatwork_api_key
  end

  private
  def namespace
    controller_name_segments = params[:controller].split('/')
    controller_name_segments.pop
    controller_namespace = controller_name_segments.join('/').camelize
  end

  def set_current_ability
    @current_ability ||= Ability.new(current_user, namespace)
  end
end
