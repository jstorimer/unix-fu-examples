# Exercise 
# ========
# Given what you just learned about fork, implement the #background_save
# method that will call the slow #save without blocking other commands.  
# In other words, perform the #save, but let the db continue processing 
# commands.
  
# Bonus Challenge
# ===============
# How would you prevent multiple background saves from occuring at the same time?

require 'yaml'

class MiniDb
  BACKUP_LOCATION = 'minidb.backup'
  
  def initialize
    @backend = Hash.new
  end
  
  def get(key)
    @backend[key]
  end
  
  def set(key, value)
    @backend[key] = value
  end
  
  def save
    sleep 3 # pretend it's slow
    
    File.write(BACKUP_LOCATION, YAML.dump(@backend))
  end
  
  def background_save
    # TODO: implement me!
  end
end

# Simple testing of the db

db = MiniDb.new

db.set('prez', 'obama')
puts db.get('prez')

db.background_save
db.set('phaser', 'stun')

db.background_save
puts db.get('phaser')
