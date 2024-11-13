module vulkan_driver_create_image_views
  use, intrinsic :: iso_c_binding
  use :: vector
  use :: forvulkan
  use :: forvulkan_parameters
  implicit none


contains


  subroutine create_image_views(swapchain_images, swapchain_image_views)
    implicit none

    ! VkImage Array
    type(vec), intent(inout) :: swapchain_images
    ! VkImageView Array
    type(vec), intent(inout) :: swapchain_image_views
    integer(c_int64_t) :: i

    swapchain_image_views = new_vec(sizeof(0_8), 0_8)
    call swapchain_image_views%resize(swapchain_images%size(), 0_8)

    do i = 1,swapchain_images%size()

    end do
  end subroutine create_image_views


end module vulkan_driver_create_image_views
