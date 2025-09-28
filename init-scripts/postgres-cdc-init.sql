-- PostgreSQL CDC Demo Database Initialization
-- This script sets up a demo database with sample tables for CDC testing


-- Create a sample users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create a sample posts table
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    title VARCHAR(200) NOT NULL,
    content TEXT,
    status VARCHAR(20) DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create a sample orders table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    product_name VARCHAR(100) NOT NULL,
    quantity INTEGER DEFAULT 1,
    price DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO users (username, email, first_name, last_name) VALUES
    ('john_doe', 'john@example.com', 'John', 'Doe'),
    ('jane_smith', 'jane@example.com', 'Jane', 'Smith'),
    ('bob_wilson', 'bob@example.com', 'Bob', 'Wilson');

INSERT INTO posts (user_id, title, content, status) VALUES
    (1, 'My First Post', 'This is my first blog post!', 'published'),
    (2, 'Learning SQL', 'SQL is a powerful language for databases.', 'published'),
    (1, 'Draft Post', 'This is a draft post.', 'draft');

INSERT INTO orders (user_id, product_name, quantity, price, status) VALUES
    (1, 'Laptop', 1, 999.99, 'completed'),
    (2, 'Mouse', 2, 29.99, 'pending'),
    (3, 'Keyboard', 1, 79.99, 'shipped');

-- Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to automatically update updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create a publication for CDC (PostgreSQL 10+)
CREATE PUBLICATION cdc_publication FOR ALL TABLES;

-- Grant necessary permissions
GRANT ALL PRIVILEGES ON DATABASE cdc_demo TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;

