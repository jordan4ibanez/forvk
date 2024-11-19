module vulkan_driver_draw_frame
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: forvulkan_parameters
  implicit none


contains


  subroutine draw_frame(logical_device, in_flight_fence)
    implicit none

    ! VkDevice
    integer(c_int64_t), intent(in), value :: logical_device
    ! VkFence
    integer(c_int64_t), intent(in), value, target :: in_flight_fence

    ! -1 is UINT64_MAX, aka, unlimited timeout.
    if (vk_wait_for_fences(logical_device, 1, c_loc(in_flight_fence), VK_TRUE, -1_8) /= VK_SUCCESS) then
      error stop
    end if

    

  end subroutine draw_frame

end module vulkan_driver_draw_frame
