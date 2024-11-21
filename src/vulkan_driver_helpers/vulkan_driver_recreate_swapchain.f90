module vulkan_driver_recreate_swapchain
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  implicit none


  private


  public :: recreate_swapchain


contains


  subroutine recreate_swapchain()
    implicit none

    call clean_up_swapchain()


  end subroutine recreate_swapchain


  subroutine clean_up_swapchain()
    implicit none

  end subroutine clean_up_swapchain


end module vulkan_driver_recreate_swapchain
