module vulkan_driver_create_graphics_pipeline
  use, intrinsic :: iso_c_binding
  use :: vulkan_shader_compiler
  implicit none


contains


  subroutine create_graphics_pipeline(logical_device)
    implicit none

    ! VkDevice
    integer(c_int64_t), intent(in), value :: logical_device
    ! VkShaderModule
    integer(c_int64_t) :: vertex_shader_module

    vertex_shader_module = compile_glsl_shaders(logical_device, "vertex.vert")

  end subroutine create_graphics_pipeline


end module vulkan_driver_create_graphics_pipeline
