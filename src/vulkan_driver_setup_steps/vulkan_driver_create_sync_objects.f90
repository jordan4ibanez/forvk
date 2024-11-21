module vulkan_driver_create_sync_objects
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vector
  implicit none


contains


  subroutine create_sync_objects(logical_device, MAX_FRAMES_IN_FLIGHT, image_available_semaphores, render_finished_semaphores, in_flight_fences)
    implicit none

    ! VkDevice
    integer(c_int64_t), intent(in), value :: logical_device
    integer(c_int64_t), intent(in), value :: MAX_FRAMES_IN_FLIGHT
    ! VkSemaphore
    type(vec), intent(inout) :: image_available_semaphores
    ! VkSemaphore
    type(vec), intent(inout) :: render_finished_semaphores
    ! VkFence
    type(vec), intent(inout) :: in_flight_fences
    type(vk_semaphore_create_info), target :: semaphore_create_info
    type(vk_fence_create_info), target :: fence_create_info
    integer(c_int64_t) :: i

    image_available_semaphores = new_vec(sizeof(VK_NULL_HANDLE), MAX_FRAMES_IN_FLIGHT)
    call image_available_semaphores%resize(MAX_FRAMES_IN_FLIGHT, VK_NULL_HANDLE)

    render_finished_semaphores = new_vec(sizeof(VK_NULL_HANDLE), MAX_FRAMES_IN_FLIGHT)
    call render_finished_semaphores%resize(MAX_FRAMES_IN_FLIGHT, VK_NULL_HANDLE)

    in_flight_fences = new_vec(sizeof(VK_NULL_HANDLE), MAX_FRAMES_IN_FLIGHT)
    call in_flight_fences%resize(MAX_FRAMES_IN_FLIGHT, VK_NULL_HANDLE)

    semaphore_create_info%s_type = VK_STRUCTURE_TYPE%SEMAPHORE_CREATE_INFO

    fence_create_info%s_type = VK_STRUCTURE_TYPE%FENCE_CREATE_INFO
    fence_create_info%flags = VK_FENCE_CREATE_SIGNALED_BIT

    do i = 1,MAX_FRAMES_IN_FLIGHT
      if (vk_create_semaphore(logical_device, c_loc(semaphore_create_info), c_null_ptr, image_available_semaphores%get(i)) /= VK_SUCCESS) then
        error stop "[Vulkan] Error: Failed to create image available semaphore"
      end if

      if (vk_create_semaphore(logical_device, c_loc(semaphore_create_info), c_null_ptr, render_finished_semaphores%get(i)) /= VK_SUCCESS) then
        error stop "[Vulkan] Error: Failed to create render finished semaphore"
      end if

      if (vk_create_fence(logical_device, c_loc(fence_create_info), c_null_ptr, in_flight_fences%get(i)) /= VK_SUCCESS) then
        error stop "[Vulkan] Error: Failed to create in flight fence"
      end if
    end do
  end subroutine create_sync_objects


end module vulkan_driver_create_sync_objects
