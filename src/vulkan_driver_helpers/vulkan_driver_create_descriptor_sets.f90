module vulkan_driver_create_descriptor_sets
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vector
  implicit none


contains


  subroutine create_descriptor_sets(logical_device, descriptor_sets, descriptor_set_layout, descriptor_pool, MAX_FRAMES_IN_FLIGHT, uniform_buffers)
    implicit none

    type(vk_device), intent(in), value :: logical_device
    ! Vk DescriptorSet Vector
    type(vec), intent(inout) :: descriptor_sets
    type(vk_descriptor_set_layout), intent(in), value :: descriptor_set_layout
    type(vk_descriptor_pool), intent(in), value :: descriptor_pool
    integer(c_int64_t), intent(in), value :: MAX_FRAMES_IN_FLIGHT
    ! Vk Buffer Vector
    type(vec), intent(inout) :: uniform_buffers
    ! Vk DescriptorSetLayout
    type(vec) :: layouts
    type(vk_descriptor_set_allocate_info), target :: alloc_info
    integer(c_int64_t) :: i
    type(vk_descriptor_buffer_info), target :: buffer_info
    type(vk_buffer), pointer :: buffer_pointer
    type(vk_write_descriptor_set), target :: descriptor_write
    type(vk_descriptor_set), pointer :: descriptor_pointer

    layouts = new_vec(sizeof(descriptor_set_layout), MAX_FRAMES_IN_FLIGHT)
    call layouts%resize(MAX_FRAMES_IN_FLIGHT, descriptor_set_layout)

    alloc_info%s_type = VK_STRUCTURE_TYPE%DESCRIPTOR_SET_ALLOCATE_INFO
    alloc_info%descriptor_pool = descriptor_pool
    alloc_info%descriptor_set_count = int(MAX_FRAMES_IN_FLIGHT)
    alloc_info%p_set_layouts = layouts%get(1_8)

    descriptor_sets = new_vec(sizeof(vk_descriptor_set()), MAX_FRAMES_IN_FLIGHT)
    call descriptor_sets%resize(MAX_FRAMES_IN_FLIGHT, vk_descriptor_set())

    if (vk_allocate_descriptor_sets(logical_device, c_loc(alloc_info), descriptor_sets%get(1_8)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to allocate descriptor sets."
    end if

    ! Don't need this no more.
    call layouts%destroy()

    do i = 1,MAX_FRAMES_IN_FLIGHT
      call c_f_pointer(uniform_buffers%get(i), buffer_pointer)

      buffer_info%buffer = buffer_pointer
      buffer_info%offset = vk_device_size(0)
      buffer_info%range = vk_device_size(sizeof(vk_buffer()))


      call c_f_pointer(descriptor_sets%get(i), descriptor_pointer)

      descriptor_write%s_type = VK_STRUCTURE_TYPE%WRITE_DESCRIPTOR_SET
      descriptor_write%dst_set = descriptor_pointer
      descriptor_write%dst_binding = 0
      descriptor_write%dst_array_element = 0
      descriptor_write%descriptor_type = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER
      descriptor_write%descriptor_count = 1
      descriptor_write%p_buffer_info = c_loc(buffer_info)
      descriptor_write%p_image_info = c_null_ptr
      descriptor_write%p_texel_buffer_view = c_null_ptr

      call vk_update_descriptor_sets(logical_device, 1, c_loc(descriptor_write), 0, c_null_ptr)
    end do
  end subroutine create_descriptor_sets


end module vulkan_driver_create_descriptor_sets
