module RecordExtensions
  module Random
    ## Return a random record from the collection.
    # > User.all.find_random
    #   User Load (43.1ms)  SELECT "users".* FROM "users" ORDER BY RANDOM() LIMIT $1  [["LIMIT", 1]]
    # => #<User id: 7680, …
    # > User.active.find_random
    #   User Load (31.2ms)  SELECT "users".* FROM "users" WHERE "users"."deleted_at" IS NULL ORDER BY RANDOM() LIMIT $1  [["LIMIT", 1]]
    # => #<User id: 4279,
    #
    # It’s faster than `#sample`, which is actually a method of Array, and has to load the whole collection:
    # > User.active.sample
    #   User Load (450.1ms)  SELECT "users".* FROM "users" WHERE "users"."deleted_at" IS NULL
    # => #<User id: 6305,
    def find_random
      offset(rand(size)).first
    end
  end
end
