module VoucherHelper
  # This method was used when we started a voucher campaign to give customers 50 Euros for free,
  # now campaign has been ended so no free vouchers, customer has to pay full amount.

  # def amounts
  #   [
  #     [t('vouchers.default_amount'), 50],
  #     ['€25,-', 75],
  #     ['€50,-', 100],
  #     ['€75,-', 125],
  #     ['€100,-', 150],
  #     ['€200,-', 250],
  #     ['€300,-', 350],
  #     ['€400,-', 450],
  #     ['€500,-', 550],
  #     ['€600,-', 650],
  #     ['€700,-', 750],
  #     ['€800,-', 850],
  #     ['€900,-', 950],
  #     ['€1000,-', 1050],
  #   ]
  # end

  def amounts
    [
      ['€25,-', 25],
      ['€50,-', 50],
      ['€75,-', 75],
      ['€100,-', 100],
      ['€200,-', 200],
      ['€300,-', 300],
      ['€400,-', 400],
      ['€500,-', 500],
      ['€600,-', 600],
      ['€700,-', 700],
      ['€800,-', 800],
      ['€900,-', 900],
      ['€1000,-', 1000],
    ]
  end
end
