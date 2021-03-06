class PaymentsController < ApplicationController
  include ActiveMerchant::Billing
  load_and_authorize_resource

  def new
    @payment = Payment.new
    @user_promo = UserPromo.new
  end

  def create_user_promo
    promo_params = params[:user_promo]
    promo_params = promo_params.merge user_id: current_user.id

    @user_promo = UserPromo.new(promo_params)
    if !@user_promo.save
      @payment = Payment.new
      render :action => :new
      return
    else
      notice = t 'promos.success'  + " " + t(:months_count, :count => @user_promo.promo.period) + "!"
      redirect_to payments_url, notice: notice
    end
  end

  def checkout
    payment_params = params[:payment]
    payment_params = payment_params.merge user_id: current_user.id, tool: :paypal

    @payment = Payment.new(payment_params)
    if !@payment.save
      render :action => :new
      return
    end

    @payment.update_attribute(:ip, request.remote_ip)

    setup_response = EXPRESS_GATEWAY.setup_purchase(@payment.amount_with_cents,
                                                    :ip => request.remote_ip,
                                                    :return_url => url_for(:controller => :payments, :action => :complete, :only_path => false),
                                                    :cancel_return_url => url_for(:controller => :payments, :action => :new, :only_path => false),
    )

    redirect_to EXPRESS_GATEWAY.redirect_url_for(setup_response.token)
  end

  def complete
    message = {notice: (t 'payments.complete')}

    @payment = current_user.current_payment(request.remote_ip)

    purchase = EXPRESS_GATEWAY.purchase(@payment.amount.to_i,
                                        :ip => request.remote_ip,
                                        :payer_id => params[:PayerID],
                                        :token => params[:token]
    )

    if !purchase.success?
      message =  {alert: purchase.message}
    end

    if !(current_user.complete_payment @payment.id, params[:PayerID])
      message = message.merge alert: (t 'payments.error')
    end

    redirect_to payments_url, message
  end

end
