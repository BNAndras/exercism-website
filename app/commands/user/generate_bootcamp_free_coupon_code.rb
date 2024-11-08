class User::GenerateBootcampFreeCouponCode
  include Mandate

  initialize_with :user

  def call
    # Easy cheap guard
    return if user_data.bootcamp_free_coupon_code.present?

    # Now things get expensive with Stripe call and lock below
    code = generate_coupon_code
    user_data.with_lock do
      return if user_data.bootcamp_free_coupon_code.present?

      user_data.update!(bootcamp_free_coupon_code: code)
    end
  end

  private
  delegate :data, to: :user, prefix: true

  memoize
  def generate_coupon_code
    promo_code = Stripe::PromotionCode.create(
      coupon: COUPON_ID,
      max_redemptions: 1,
      metadata: {
        user_id: user.id
      }
    )
    promo_code.code
  end

  COUPON_ID = "OarhoKrd".freeze
end