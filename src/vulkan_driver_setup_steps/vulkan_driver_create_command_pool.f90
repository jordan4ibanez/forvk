module vulkan_driver_create_command_pool
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: forvulkan_parameters
  use :: vulkan_driver_find_queue_families
  implicit none


contains


  subroutine create_command_pool(physical_device)
    implicit none

    ! VkPhysicalDevice
    integer(c_int64_t), intent(in), value :: physical_device
    type(forvulkan_queue_family_indices) :: queue_family_indices





  end subroutine create_command_pool


end module vulkan_driver_create_command_pool
