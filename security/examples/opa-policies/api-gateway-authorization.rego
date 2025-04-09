package api.authorization

# Default to deny
default allow = false

# Allow if the user has the required role for the path and method
allow {
    # Extract the required role for the path and method
    required_roles := role_permissions[input.path][input.method]
    
    # Check if the user has any of the required roles
    user_roles := user_roles[input.user]
    has_role(user_roles, required_roles)
}

# Check if the user has any of the required roles
has_role(user_roles, required_roles) {
    # Check if any of the user's roles are in the required roles
    user_role := user_roles[_]
    required_role := required_roles[_]
    user_role == required_role
}

# Define role-based permissions for different API paths and methods
role_permissions = {
    "/api/users": {
        "GET": ["admin", "reader"],
        "POST": ["admin"],
        "PUT": ["admin"],
        "DELETE": ["admin"]
    },
    "/api/products": {
        "GET": ["admin", "reader", "user"],
        "POST": ["admin", "editor"],
        "PUT": ["admin", "editor"],
        "DELETE": ["admin"]
    },
    "/api/orders": {
        "GET": ["admin", "user"],
        "POST": ["admin", "user"],
        "PUT": ["admin"],
        "DELETE": ["admin"]
    }
}

# Define user roles (in a real system, these would be fetched from a database or identity provider)
user_roles = {
    "alice": ["admin"],
    "bob": ["editor"],
    "charlie": ["reader"],
    "david": ["user"]
}
