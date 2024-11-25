module vulkan_driver_create_descriptor_set_layout
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  implicit none


contains


  subroutine create_descriptor_set_layout()
    implicit none

    type(vk_descriptor_set_layout_binding), target :: ubo_layout_binding

    ubo_layout_binding%binding = 0
    ubo_layout_binding%descriptor_type = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER
    ubo_layout_binding%descriptor_count = 1
    ubo_layout_binding%stage_flags = VK_SHADER_STAGE_VERTEX_BIT
    ubo_layout_binding%p_immutable_samplers = c_null_ptr
    

  end subroutine create_descriptor_set_layout


end module vulkan_driver_create_descriptor_set_layout
