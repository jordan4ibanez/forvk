module vulkan_driver_create_descriptor_set_layout
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  implicit none


contains


  subroutine create_descriptor_set_layout(logical_device, descriptor_set_layout)
    implicit none

    type(vk_device), intent(in), value :: logical_device
    type(vk_descriptor_set_layout), intent(inout) :: descriptor_set_layout
    type(vk_descriptor_set_layout_binding), target :: ubo_layout_binding
    type(vk_descriptor_set_layout_create_info), target :: layout_info

    ubo_layout_binding%binding = 0
    ubo_layout_binding%descriptor_type = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER
    ubo_layout_binding%descriptor_count = 1
    ubo_layout_binding%stage_flags = VK_SHADER_STAGE_VERTEX_BIT
    ubo_layout_binding%p_immutable_samplers = c_null_ptr

    layout_info%s_type = VK_STRUCTURE_TYPE%DESCRIPTOR_SET_LAYOUT_CREATE_INFO
    layout_info%binding_count = 1
    layout_info%p_bindings = c_loc(ubo_layout_binding)

    if (vk_create_descriptor_set_layout(logical_device, c_loc(layout_info), c_null_ptr, descriptor_set_layout) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create descriptor set layout."
    end if
  end subroutine create_descriptor_set_layout


end module vulkan_driver_create_descriptor_set_layout
