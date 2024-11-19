module vulkan_driver_create_sync_objects
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: forvulkan_parameters
  implicit none


contains


  subroutine create_sync_objects()
    implicit none

    type(vk_semaphore_create_info), target :: semaphore_create_info

    



  end subroutine create_sync_objects


end module vulkan_driver_create_sync_objects
