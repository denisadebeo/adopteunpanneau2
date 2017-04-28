class Panneau < ApplicationRecord
	scope :ville, -> (ville) { where ville: ville }
end
