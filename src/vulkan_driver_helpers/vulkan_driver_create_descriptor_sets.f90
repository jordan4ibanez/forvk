module vulkan_driver_create_descriptor_sets
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vector
  implicit none


contains


  subroutine create_descriptor_sets(logical_device, descriptor_sets, descriptor_set_layout, descriptor_pool, MAX_FRAMES_IN_FLIGHT)
    implicit none

    type(vk_device), intent(in), value :: logical_device
    type(vec), intent(inout) :: descriptor_sets
    type(vk_descriptor_set_layout), intent(in), value :: descriptor_set_layout
    type(vk_descriptor_pool), intent(in), value :: descriptor_pool
    integer(c_int64_t), intent(in), value :: MAX_FRAMES_IN_FLIGHT
    ! Vk DescriptorSetLayout
    type(vec) :: layouts
    type(vk_descriptor_set_allocate_info), target :: alloc_info

    layouts = new_vec(sizeof(descriptor_set_layout), MAX_FRAMES_IN_FLIGHT)
    call layouts%resize(MAX_FRAMES_IN_FLIGHT, descriptor_set_layout)

    alloc_info%s_type = VK_STRUCTURE_TYPE%DESCRIPTOR_SET_ALLOCATE_INFO
    alloc_info%descriptor_pool = descriptor_pool
    alloc_info%descriptor_set_count = int(MAX_FRAMES_IN_FLIGHT)
    alloc_info%p_set_layouts = layouts%get(1_8)

    descriptor_sets = new_vec(sizeof(vk_descriptor_set()), MAX_FRAMES_IN_FLIGHT)
    call descriptor_sets%resize(MAX_FRAMES_IN_FLIGHT, vk_descriptor_set())

    if (vk_allocate_descriptor_sets(logical_device, c_loc(alloc_info), descriptor_sets%get(1_8)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to allocate descriptor sets."
    end if
  end subroutine create_descriptor_sets


end module vulkan_driver_create_descriptor_sets
