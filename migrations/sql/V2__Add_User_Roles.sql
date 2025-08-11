-- V2__Add_User_Roles.sql
-- Add role-based access control

CREATE TYPE user_role AS ENUM ('admin', 'manager', 'user');

ALTER TABLE users
ADD COLUMN role user_role NOT NULL DEFAULT 'user';

CREATE TABLE permissions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE role_permissions (
    role user_role NOT NULL,
    permission_id INTEGER NOT NULL REFERENCES permissions(id),
    PRIMARY KEY (role, permission_id)
);

-- Insert default permissions
INSERT INTO permissions (name, description) VALUES
    ('project.create', 'Create new projects'),
    ('project.update', 'Update project details'),
    ('project.delete', 'Delete projects'),
    ('task.create', 'Create new tasks'),
    ('task.update', 'Update task details'),
    ('task.delete', 'Delete tasks'),
    ('user.view', 'View user details'),
    ('user.create', 'Create new users'),
    ('user.update', 'Update user details'),
    ('user.delete', 'Delete users');
    
-- Assign permissions to roles
-- Admin role has all permissions
INSERT INTO role_permissions (role, permission_id)
SELECT 'admin', id FROM permissions;

-- Manager role permissions
INSERT INTO role_permissions (role, permission_id)
SELECT 'manager', id FROM permissions
WHERE name IN (
    'project.create',
    'project.update',
    'task.create',
    'task.update',
    'task.delete',
    'user.view'
);

-- User role permissions
INSERT INTO role_permissions (role, permission_id)
SELECT 'user', id FROM permissions
WHERE name IN (
    'task.create',
    'task.update',
    'user.view'
);
