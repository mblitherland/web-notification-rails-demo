require 'web-push'

class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @pub_key ||= Rails.configuration.vapid_public_key
    @priv_key ||= Rails.configuration.vapid_private_key
    sub = current_user.subscription
    @push_info = {
      enabled: sub.nil? ? false : true,
      endpoint: sub.nil? ? nil : sub[:endpoint],
      p256dh: sub.nil? ? nil : sub[:p256dh],
      auth: sub.nil? ? nil : sub[:auth]
    }
  end

  def enable
    puts('subscribing')
    sub = Subscription.new
    sub[:user_id] = current_user.id
    sub[:endpoint] = params[:endpoint]
    sub[:p256dh] = params[:p256dh]
    sub[:auth] = params[:auth]
    sub.save
    render json: {}
  end

  def disable
    sub = Subscription.where(user_id: current_user.id)
    sub.destroy_all
    render json: {}
  end

  def push_to_me
    sub = current_user.subscription
    if sub.nil?
      redirect_to '/', alert: 'You do not have a subscription'
    else
      send_sub(params[:message], sub)
      redirect_to '/', notice: 'Attempted to send message'
    end
  end

  def push_to_all
    subs = Subscription.all
    subs.each { |sub| send_sub(params[:message], sub) }
    redirect_to '/', notice: "Attempted to send #{subs.count} messages"
  end

  private

  def send_sub(message, sub)
    puts('sending now')
    result = WebPush.payload_send(
      message: message,
      endpoint: sub[:endpoint],
      p256dh: sub[:p256dh],
      auth: sub[:auth],
      vapid: {
        subject: "WebNote #{Time.now.to_i}",
        public_key: Rails.configuration.vapid_public_key,
        private_key: Rails.configuration.vapid_private_key
      },
      ssl_timeout: 5,
      open_timeout: 5,
      read_timeout: 5
    )
    puts("response: #{result.code}")
    puts('headers:')
    result.header.each_header { |k, v| puts("- #{k} = #{v}") }
    puts("body: #{result.body}")
    puts('after sending')
  end

end
