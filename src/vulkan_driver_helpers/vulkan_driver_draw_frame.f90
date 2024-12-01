module vulkan_driver_draw_frame
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vulkan_driver_record_command_buffer
  use :: vulkan_driver_recreate_swapchain
  use :: vulkan_driver_update_uniform_buffer
  implicit none


contains

  !* Implementation note: indices_size needs to be baked into the hashmap.
  !* It is currently a hackjob.
!! FIXME: WHY ARE THERE SO MANY DUMMY VARS AHHH
  subroutine draw_frame(logical_device, current_frame, MAX_FRAMES_IN_FLIGHT, in_flight_fences, image_available_semaphores, render_finished_semaphores, swapchain, command_buffers, render_pass, swapchain_framebuffers, swapchain_extent, graphics_pipeline, graphics_queue, present_queue, physical_device, window_surface, swapchain_images, swapchain_image_format, swapchain_image_views, framebuffer_resized, vertex_buffer, index_buffer, indices_size, uniform_buffers_mapped, descriptor_sets, pipeline_layout)
    implicit none

    type(vk_device), intent(in), value :: logical_device
    integer(c_int64_t), intent(inout) :: current_frame
    integer(c_int64_t), intent(in), value :: MAX_FRAMES_IN_FLIGHT
    ! Vk Fence Vector
    type(vec), intent(inout) :: in_flight_fences
    ! Vk Semaphore Vector
    type(vec), intent(inout) :: image_available_semaphores
    ! Vk Semaphore Vector
    type(vec), intent(inout) :: render_finished_semaphores
    type(vk_swapchain_khr), intent(inout) :: swapchain
    ! Vk CommandBuffer Vector
    type(vec), intent(inout) :: command_buffers
    type(vk_render_pass), intent(in), value :: render_pass
    ! Vk Framebuffer Vector
    type(vec), intent(inout) :: swapchain_framebuffers
    type(vk_extent_2d), intent(inout) :: swapchain_extent
    type(vk_pipeline), intent(in), value :: graphics_pipeline
    type(vk_queue), intent(in), value :: graphics_queue
    type(vk_queue), intent(in), value, target :: present_queue
    type(vk_physical_device), intent(in), value :: physical_device
    type(vk_surface_khr), intent(inout) :: window_surface
    ! Vk Image Vector
    type(vec), intent(inout) :: swapchain_images
    type(vk_format), intent(inout) :: swapchain_image_format
    ! Vk ImageView Vector
    type(vec), intent(inout) :: swapchain_image_views
    logical(c_bool), intent(inout) :: framebuffer_resized
    type(vk_buffer), intent(in), value :: vertex_buffer
    type(vk_buffer), intent(in), value :: index_buffer
    integer(c_int32_t), intent(in), value :: indices_size
    ! void * (C pure generic Vector)
    type(vec), intent(inout) :: uniform_buffers_mapped
    ! Vk DescriptorSet Vector
    type(vec), intent(inout) :: descriptor_sets
    type(vk_pipeline_layout), intent(in), value :: pipeline_layout
    ! uint32_t
    integer(c_int32_t), target :: image_index
    type(vk_submit_info), target :: submit_info
    ! Vk Semaphore[]
    type(vk_semaphore), dimension(1), target :: wait_semaphores
    ! VkPipelineStageFlags[]
    integer(c_int32_t), dimension(1), target :: wait_stages
    ! Vk Semaphore[]
    type(vk_semaphore), dimension(1), target :: signal_semaphores
    type(vk_present_info_khr), target :: present_info
    type(vk_swapchain_khr), dimension(1), target :: swapchains
    type(vk_fence), pointer :: fence_pointer
    type(vk_semaphore), pointer :: semaphore_pointer
    type(vk_command_buffer), pointer :: command_buffer_pointer
    integer(c_int32_t) :: acquire_result

    ! -1 is UINT64_MAX, aka, unlimited timeout.
    if (vk_wait_for_fences(logical_device, 1, in_flight_fences%get(current_frame), VK_TRUE, -1_8) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to wait for fences."
    end if

    call c_f_pointer(image_available_semaphores%get(current_frame), semaphore_pointer)
    acquire_result = vk_acquire_next_image_khr(logical_device, swapchain, -1_8, semaphore_pointer, vk_fence(VK_NULL_HANDLE), image_index)

    if (vk_reset_fences(logical_device, 1, in_flight_fences%get(current_frame)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to reset in flight fence."
    end if

    ! We now translate this to Fortran indexing.
    ! todo: make this into a helper function.
    image_index = image_index + 1

    call c_f_pointer(command_buffers%get(current_frame), command_buffer_pointer)
    if (vk_reset_command_buffer(command_buffer_pointer, 0) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Faield to reset command buffer."
    end if

    call record_command_buffer(command_buffer_pointer, image_index, render_pass, swapchain_framebuffers, swapchain_extent, graphics_pipeline, vertex_buffer, index_buffer, indices_size, descriptor_sets, current_frame, pipeline_layout)

    submit_info%s_type = VK_STRUCTURE_TYPE%SUBMIT_INFO

    call c_f_pointer(image_available_semaphores%get(current_frame), semaphore_pointer)
    wait_semaphores = [semaphore_pointer]

    wait_stages = [VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT]

    call update_uniform_buffer(current_frame, uniform_buffers_mapped)

    submit_info%wait_semaphore_count = 1
    submit_info%p_wait_semaphores = c_loc(wait_semaphores)
    submit_info%p_wait_dst_stage_mask = c_loc(wait_stages)
    submit_info%command_buffer_count = 1
    submit_info%p_command_buffers = c_loc(command_buffer_pointer)

    call c_f_pointer(render_finished_semaphores%get(current_frame), semaphore_pointer)
    signal_semaphores = [semaphore_pointer]
    submit_info%signal_semaphore_count = 1
    submit_info%p_signal_semaphores = c_loc(signal_semaphores)

    call c_f_pointer(in_flight_fences%get(current_frame), fence_pointer)
    if (vk_queue_submit(graphics_queue, 1, c_loc(submit_info), fence_pointer) /= VK_SUCCESS) then
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

    ! The Vulkan tutorial is very vague on this part.
    ! If you're reading this, this part was supposed to be split up like so lol.
    if (acquire_result == VK_ERROR_OUT_OF_DATE_KHR .or. acquire_result == VK_SUBOPTIMAL_KHR .or. framebuffer_resized) then
      call recreate_swapchain(logical_device, physical_device, window_surface, swapchain, swapchain_images, swapchain_image_format, swapchain_extent, swapchain_image_views, swapchain_framebuffers, render_pass)
      framebuffer_resized = .false.
      print*,"recreating swap chain"
      ! This early return prevents a deadlock.
      return
    else if (acquire_result /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to aqcuire next swapchain image."
    end if

    ! Tick and cycle frames.
    current_frame = mod(current_frame, MAX_FRAMES_IN_FLIGHT) + 1
  end subroutine draw_frame

end module vulkan_driver_draw_frame
