module vulkan_driver_draw_frame
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: forvulkan_parameters
  use :: vulkan_driver_record_command_buffer
  implicit none


contains


  subroutine draw_frame(logical_device, in_flight_fence, image_available_semaphore, swapchain, command_buffer, render_pass, swapchain_framebuffers, swapchain_extent, graphics_pipeline, render_finished_semaphore)
    implicit none

    ! VkDevice
    integer(c_int64_t), intent(in), value :: logical_device
    ! VkFence
    integer(c_int64_t), intent(in), value, target :: in_flight_fence
    ! VkSemaphore
    integer(c_int64_t), intent(in), value :: image_available_semaphore
    ! VkSwapchainKHR
    integer(c_int64_t), intent(in), value :: swapchain
    ! VkCommandBuffer
    integer(c_int64_t), intent(in), value, target :: command_buffer
    ! VkRenderPass
    integer(c_int64_t), intent(in), value :: render_pass
    ! VkFramebuffer
    type(vec), intent(inout) :: swapchain_framebuffers
    ! VkExtent2D
    type(vk_extent_2d), intent(in), value :: swapchain_extent
    ! VkPipeline
    integer(c_int64_t), intent(in), value :: graphics_pipeline
    ! VkSemaphore
    integer(c_int64_t), intent(in), value :: render_finished_semaphore
    ! uint32_t
    integer(c_int32_t), target :: image_index
    type(vk_submit_info), target :: submit_info
    ! VkSemaphore[]
    integer(c_int64_t), dimension(1), target :: wait_semaphores
    ! VkPipelineStageFlags[]
    integer(c_int32_t), dimension(1), target :: wait_stages
    ! VkSemaphore[]
    integer(c_int64_t), dimension(1), target :: signal_semaphores

    ! -1 is UINT64_MAX, aka, unlimited timeout.
    if (vk_wait_for_fences(logical_device, 1, c_loc(in_flight_fence), VK_TRUE, -1_8) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to wait for fences."
    end if

    if (vk_acquire_next_image_khr(logical_device, swapchain, -1_8, image_available_semaphore, VK_NULL_HANDLE, image_index) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to aqcuire next image."
    end if

    ! We now translate this to Fortran indexing.
    ! todo: make this into a helper function.
    image_index = image_index + 1


    if (vk_reset_command_buffer(command_buffer, 0) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Faield to reset command buffer."
    end if

    call record_command_buffer(command_buffer, image_index, render_pass, swapchain_framebuffers, swapchain_extent, graphics_pipeline)

    submit_info%s_type = VK_STRUCTURE_TYPE%SUBMIT_INFO

    wait_semaphores = [image_available_semaphore]

    wait_stages = [VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT]

    submit_info%wait_semaphore_count = 1
    submit_info%p_wait_semaphores = c_loc(wait_semaphores)
    submit_info%p_wait_dst_stage_mask = c_loc(wait_stages)
    submit_info%command_buffer_count = 1
    submit_info%p_command_buffers = c_loc(command_buffer)

    signal_semaphores = [render_finished_semaphore]
    submit_info%signal_semaphore_count = 1
    submit_info%p_signal_semaphores = c_loc(signal_semaphores)


  end subroutine draw_frame

end module vulkan_driver_draw_frame
