module vulkan_driver_create_shaders
  use, intrinsic :: iso_c_binding
  use :: vulkan_shader_compiler
  implicit none

contains

  subroutine create_shaders()
    implicit none

    type(compiled_shader_code) :: vert

    vert = compile_glsl_shaders("vertex.vert")
  end subroutine create_shaders
end module vulkan_driver_create_shaders
