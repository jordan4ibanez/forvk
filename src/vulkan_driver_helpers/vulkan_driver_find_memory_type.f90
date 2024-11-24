module vulkan_driver_find_memory_type
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  implicit none


contains


  function find_memory_type(physical_device, type_filter, properties) result(t)
    implicit none

    type(vk_physical_device), intent(in), value :: physical_device
    integer(c_int32_t), intent(in), value :: type_filter
    integer(c_int32_t), intent(in), value :: properties
    integer(c_int32_t) :: t
    integer(c_int32_t) :: i
    type(vk_physical_device_memory_properties), target :: mem_properties

    call vk_get_physical_device_memory_properties(physical_device, c_loc(mem_properties))

    do i = 0,mem_properties%memory_type_count - 1
      if (iand(type_filter, shiftl(1, i)) /= 0 .and. iand(mem_properties%memory_types(i + 1)%property_flags, properties) == properties) then
        t = i
        return
      end if
    end do

    error stop "[Vulkan] Error: Failed to find suitable memory type."
  end function find_memory_type


end module vulkan_driver_find_memory_type
