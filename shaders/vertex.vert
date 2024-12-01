#version 420

layout(location = 0) in vec2 inPosition;
layout(location = 1) in vec3 inColor;

layout(location = 0) out vec3 fragColor;

layout(binding = 0) uniform UniformBufferObject {
    mat4 camera_matrix;
    mat4 object_matrix;
} ubo;

void main() {
    gl_Position = ubo.camera_matrix * ubo.object_matrix * vec4(inPosition, 0.0, 1.0);
    fragColor = inColor;
}