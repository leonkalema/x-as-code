package kubernetes.admission

# Deny pods that run as root
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    container := input.request.object.spec.containers[_]
    not container.securityContext.runAsNonRoot
    msg := sprintf("Container %q must set securityContext.runAsNonRoot", [container.name])
}

# Deny pods that don't set securityContext
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    container := input.request.object.spec.containers[_]
    not container.securityContext
    msg := sprintf("Container %q must set securityContext", [container.name])
}

# Deny pods that use privileged mode
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    container := input.request.object.spec.containers[_]
    container.securityContext.privileged
    msg := sprintf("Container %q must not set securityContext.privileged", [container.name])
}

# Deny pods with hostNetwork, hostPID, hostIPC access
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    input.request.object.spec.hostNetwork
    msg := "Pod must not use host network"
}

deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    input.request.object.spec.hostPID
    msg := "Pod must not use host PID namespace"
}

deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    input.request.object.spec.hostIPC
    msg := "Pod must not use host IPC namespace"
}

# Require pods to have resource limits
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    container := input.request.object.spec.containers[_]
    not container.resources.limits
    msg := sprintf("Container %q must set resources.limits", [container.name])
}
