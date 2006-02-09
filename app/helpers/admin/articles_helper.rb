module Admin::ArticlesHelper
  def flag_status
    @flag_status ||= { :unpublished => 'flag_red',
                       :pending     => 'flag_yellow',
                       :published   => 'flag_green' }
  end
end
