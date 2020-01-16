class Dog
    attr_reader :breed, :id
    attr_accessor :name

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end
    def self.create_table
        sql = <<-SQL 
        CREATE TABLE dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        ) 
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
 
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(attributes)
        dog = Dog.new(attributes)
        dog.save
    end

    def self.new_from_db(row)
        dog = self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        SQL
        self.new_from_db(DB[:conn].execute(sql, id)[0])
    end

    def self.find_or_create_by(attributes)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attributes[:name], attributes[:breed])
        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
            dog = Dog.create(attributes)
        end
        dog
    end

    def self.find_by_name(name)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
        dog_data = dog[0]
        dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end