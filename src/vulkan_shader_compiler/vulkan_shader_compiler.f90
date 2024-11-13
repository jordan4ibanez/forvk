module vulkan_shader_compiler
  use, intrinsic :: iso_c_binding
  use :: shaderc_bindings
  implicit none


contains


  subroutine compile_glsl_shaders()
    implicit none

    type(c_ptr) :: shader_compiler_pointer

    shader_compiler_pointer = shaderc_compiler_initialize()

  end subroutine compile_glsl_shaders


end module vulkan_shader_compiler
