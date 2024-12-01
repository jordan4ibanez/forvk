module vulkan_driver_create_descriptor_pool
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  implicit none


contains


  subroutine create_descriptor_pool(logical_device, descriptor_pool, MAX_FRAMES_IN_FLIGHT)
    implicit none

    type(vk_device), intent(in), value :: logical_device
    type(vk_descriptor_pool), intent(inout) :: descriptor_pool
    integer(c_int64_t), intent(in), value :: MAX_FRAMES_IN_FLIGHT
    type(vk_descriptor_pool_size), target :: pool_size
    type(vk_descriptor_pool_create_info), target :: pool_info

    pool_size%type = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER
    pool_size%descriptor_count = int(MAX_FRAMES_IN_FLIGHT)

    pool_info%s_type = VK_STRUCTURE_TYPE%DESCRIPTOR_POOL_CREATE_INFO
    pool_info%pool_size_count = 1
    pool_info%p_pool_sizes = c_loc(pool_size)
    pool_info%max_sets = int(MAX_FRAMES_IN_FLIGHT)

    if (vk_create_descriptor_pool(logical_device, c_loc(pool_info), c_null_ptr, descriptor_pool) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create descriptor pool."
    end if
  end subroutine create_descriptor_pool


end module vulkan_driver_create_descriptor_pool
