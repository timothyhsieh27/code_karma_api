# Clients own projects and projects may be included in several devprojects
class Project < ApplicationRecord
  belongs_to :client
  has_many :developerproject
end
