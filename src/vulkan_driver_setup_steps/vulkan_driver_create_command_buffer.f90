module vulkan_driver_create_command_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vector
  implicit none


contains


  subroutine create_command_buffers(logical_device, MAX_FRAMES_IN_FLIGHT, command_pool, command_buffers)
    implicit none

    type(vk_device), intent(in), value :: logical_device
    integer(c_int64_t), intent(in), value :: MAX_FRAMES_IN_FLIGHT
    ! VkCommandPool
    integer(c_int64_t), intent(in), value :: command_pool
    ! VkCommandBuffer
    type(vec), intent(inout) :: command_buffers
    type(vk_command_buffer_allocate_info), target :: allocate_info

    command_buffers = new_vec(sizeof(VK_NULL_HANDLE), MAX_FRAMES_IN_FLIGHT)
    call command_buffers%resize(MAX_FRAMES_IN_FLIGHT, VK_NULL_HANDLE)

    allocate_info%s_type = VK_STRUCTURE_TYPE%COMMAND_BUFFER_ALLOCATE_INFO
    allocate_info%command_pool = command_pool
    allocate_info%level = VK_COMMAND_BUFFER_LEVEL_PRIMARY
    allocate_info%command_buffer_count = int(MAX_FRAMES_IN_FLIGHT, c_int32_t)

    if (vk_allocate_command_buffers(logical_device, c_loc(allocate_info), command_buffers%get(1_8)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to allocate command buffers."
    end if
  end subroutine create_command_buffers


end module vulkan_driver_create_command_buffer
