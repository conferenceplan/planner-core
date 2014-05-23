
module PlannerUtils

  # Calculate a cantor pairing.
  # See http://en.wikipedia.org/wiki/Cantor_pairing_function  
  def self.calculate_pairing(x,y)
    (x + y) * (x + y + 1) / 2 + y
  end
  
end
