module vulkan_driver_draw_frame
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vulkan_driver_record_command_buffer
  implicit none


contains


  subroutine draw_frame(logical_device, current_frame, MAX_FRAMES_IN_FLIGHT, in_flight_fences, image_available_semaphores, render_finished_semaphores, swapchain, command_buffers, render_pass, swapchain_framebuffers, swapchain_extent, graphics_pipeline, graphics_queue, present_queue)
    implicit none

    ! VkDevice
    integer(c_int64_t), intent(in), value :: logical_device
    integer(c_int64_t), intent(inout) :: current_frame
    integer(c_int64_t), intent(in), value :: MAX_FRAMES_IN_FLIGHT
    ! VkFence
    type(vec), intent(inout) :: in_flight_fences
    ! VkSemaphore
    type(vec), intent(inout) :: image_available_semaphores
    ! VkSemaphore
    type(vec), intent(inout) :: render_finished_semaphores
    ! VkSwapchainKHR
    integer(c_int64_t), intent(in), value :: swapchain
    ! VkCommandBuffer
    type(vec), intent(inout) :: command_buffers
    ! VkRenderPass
    integer(c_int64_t), intent(in), value :: render_pass
    ! VkFramebuffer
    type(vec), intent(inout) :: swapchain_framebuffers
    ! VkExtent2D
    type(vk_extent_2d), intent(in), value :: swapchain_extent
    ! VkPipeline
    integer(c_int64_t), intent(in), value :: graphics_pipeline
    ! VkQueue
    integer(c_int64_t), intent(in), value :: graphics_queue
    ! VkQueue
    integer(c_int64_t), intent(in), value, target :: present_queue
    ! uint32_t
    integer(c_int32_t), target :: image_index
    type(vk_submit_info), target :: submit_info
    ! VkSemaphore[]
    integer(c_int64_t), dimension(1), target :: wait_semaphores
    ! VkPipelineStageFlags[]
    integer(c_int32_t), dimension(1), target :: wait_stages
    ! VkSemaphore[]
    integer(c_int64_t), dimension(1), target :: signal_semaphores
    type(vk_present_info_khr), target :: present_info
    ! VkSwapchainKHR[]
    integer(c_int64_t), dimension(1), target :: swapchains
    integer(c_int64_t), pointer :: semaphore, fence, command_buffer

    ! -1 is UINT64_MAX, aka, unlimited timeout.
    if (vk_wait_for_fences(logical_device, 1, in_flight_fences%get(current_frame), VK_TRUE, -1_8) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to wait for fences."
    end if

    if (vk_reset_fences(logical_device, 1, in_flight_fences%get(current_frame)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to reset in flight fence."
    end if

    call c_f_pointer(image_available_semaphores%get(current_frame), semaphore)
    if (vk_acquire_next_image_khr(logical_device, swapchain, -1_8, semaphore, VK_NULL_HANDLE, image_index) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to aqcuire next image."
    end if

    ! We now translate this to Fortran indexing.
    ! todo: make this into a helper function.
    image_index = image_index + 1


    call c_f_pointer(command_buffers%get(current_frame), command_buffer)
    if (vk_reset_command_buffer(command_buffer, 0) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Faield to reset command buffer."
    end if

    call record_command_buffer(command_buffer, image_index, render_pass, swapchain_framebuffers, swapchain_extent, graphics_pipeline)

    submit_info%s_type = VK_STRUCTURE_TYPE%SUBMIT_INFO

    call c_f_pointer(image_available_semaphores%get(current_frame), semaphore)
    wait_semaphores = [semaphore]

    wait_stages = [VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT]

    submit_info%wait_semaphore_count = 1
    submit_info%p_wait_semaphores = c_loc(wait_semaphores)
    submit_info%p_wait_dst_stage_mask = c_loc(wait_stages)
    submit_info%command_buffer_count = 1
    submit_info%p_command_buffers = c_loc(command_buffer)

    call c_f_pointer(render_finished_semaphores%get(current_frame), semaphore)
    signal_semaphores = [semaphore]
    submit_info%signal_semaphore_count = 1
    submit_info%p_signal_semaphores = c_loc(signal_semaphores)

    call c_f_pointer(in_flight_fences%get(current_frame), fence)
    if (vk_queue_submit(graphics_queue, 1, c_loc(submit_info), fence) /= VK_SUCCESS) then
      error stop
    end if

    present_info%s_type = VK_STRUCTURE_TYPE%PRESENT_INFO_KHR

    present_info%wait_semaphore_count = 1
    present_info%p_wait_semaphores = c_loc(signal_semaphores)

    swapchains = [swapchain]

    ! Now move it back.
    ! todo: this needs to be removed!
    image_index = image_index - 1

    present_info%swapchain_count = 1
    present_info%p_swapchains = c_loc(swapchains)
    present_info%p_image_indices = c_loc(image_index)

    present_info%p_results = c_null_ptr

    if (vk_queue_present_khr(present_queue, c_loc(present_info)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to present queue."
    end if

    ! Tick and cycle frames.
    current_frame = mod(current_frame, MAX_FRAMES_IN_FLIGHT) + 1
  end subroutine draw_frame

end module vulkan_driver_draw_frame
