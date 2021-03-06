class UnlockRequest < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :message
  attr_protected :status

  def is_new?
    self.status == 'new'
  end

  def is_declined?
    self.status == 'declined'
  end

  def is_accepted?
    self.status == 'accepted'
  end

  def accept!
    user.set_unlock
    update_attribute(:status, 'accepted')
    WombatMailer.send_unlock_notification(self.user_id).deliver
  end

  def decline!
    self.update_attribute(:status, 'declined')
  end
end