require 'web-push'

class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @pub_key ||= Rails.configuration.vapid_public_key
    @subs_info = current_user.subscriptions
  end

  def enable
    sub = Subscription.new
    sub[:user_id] = current_user.id
    sub[:endpoint] = params[:endpoint]
    sub[:p256dh] = params[:p256dh]
    sub[:auth] = params[:auth]
    sub[:user_agent] = params[:user_agent]
    sub[:enabled] = true
    sub.save
    render json: {}
  end

  def disable
    endpoint = params[:endpoint]
    current_user.subscriptions.each do |sub|
      current_user.subscriptions.delete(sub) if sub.endpoint == endpoint
    end
    render json: {}
  end

  def push_to_me
    subs = current_user.subscriptions
    if subs.empty?
      redirect_to '/', alert: 'You do not have a subscription'
    else
      subs.each do |sub|
        send_sub(params[:message], sub) if sub.enabled
      end
      redirect_to '/', notice: 'Attempted to send messages'
    end
  end

  def push_to_all
    subs = Subscription.where(enabled: true)
    subs.each { |sub| send_sub(params[:message], sub) }
    redirect_to '/', notice: "Attempted to send #{subs.count} messages"
  end

  private

  def send_sub(message, sub)
    begin
      WebPush.payload_send(
        message: message,
        endpoint: sub[:endpoint],
        p256dh: sub[:p256dh],
        auth: sub[:auth],
        vapid: {
          subject: 'mailto: michael.litherland@gmail.com',
          public_key: Rails.configuration.vapid_public_key,
          private_key: Rails.configuration.vapid_private_key
        },
        ssl_timeout: 5,
        open_timeout: 5,
        read_timeout: 5
      )
    rescue WebPush::Unauthorized
      sub[:enabled] = false
      sub[:disable_reason] = 'Unauthorized exception'
      sub.save
    rescue WebPush::ExpiredSubscription
      sub[:enabled] = false
      sub[:disable_reason] = 'Expired exception'
      sub.save
    rescue => e
      sub[:enabled] = false
      sub[:disable_reason] = "Unhandled exception #{e}"
    end
  end
end
