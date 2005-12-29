module LiquidFilter
  def textilize(input)
    RedCloth.new(input.to_s).to_html
  end
end