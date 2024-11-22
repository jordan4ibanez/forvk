module vulkan_driver_clean_up_swapchain
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vector
  implicit none


contains


  subroutine clean_up_swapchain(logical_device, swapchain_framebuffers, swapchain_image_views, swapchain)
    implicit none

    type(vk_device), intent(in), value :: logical_device
    ! Vk Framebuffer Vector
    type(vec), intent(inout) :: swapchain_framebuffers
    ! Vk ImageView Vector
    type(vec), intent(inout) :: swapchain_image_views
    integer(c_int64_t) :: i
    type(vk_framebuffer), pointer :: framebuffer_pointer
    type(vk_image_view), pointer :: image_view_pointer
    type(vk_swapchain_khr), intent(inout) :: swapchain

    do i = 1,swapchain_framebuffers%size()
      call c_f_pointer(swapchain_framebuffers%get(i), framebuffer_pointer)
      call vk_destroy_framebuffer(logical_device, framebuffer_pointer, c_null_ptr)
    end do

    do i = 1,swapchain_image_views%size()
      call c_f_pointer(swapchain_image_views%get(i), image_view_pointer)
      call vk_destroy_image_view(logical_device, image_view_pointer, c_null_ptr)
    end do

    call vk_destroy_swapchain_khr(logical_device, swapchain, c_null_ptr)
  end subroutine clean_up_swapchain


end module vulkan_driver_clean_up_swapchain
