module vulkan_driver_create_validation_layers
  use, intrinsic :: iso_c_binding
  use :: vector
  use :: forvulkan
  use :: forvulkan_parameters
  use :: string_f90
  implicit none


contains


  subroutine create_required_validation_layers(required_validation_layers, DEBUG_MODE)
    implicit none

    ! const char *
    type(vec), intent(inout) :: required_validation_layers
    logical(c_bool), intent(in), value :: DEBUG_MODE
    character(len = :, kind = c_char), pointer :: layer_name

    ! If we're not in debug mode, don't bother with this.
    if (.not. DEBUG_MODE) then
      return
    end if

    ! Create validation layers that we need.

    print"(A)","[Vulkan]: Creating required validation layers."

    layer_name => null()
    required_validation_layers = new_vec(sizeof(c_null_ptr), 0_8)

    allocate(character(len = 28, kind = c_char) :: layer_name)
    layer_name = "VK_LAYER_KHRONOS_validation"//achar(0)
    call required_validation_layers%push_back(c_loc(layer_name))
  end subroutine create_required_validation_layers


  subroutine ensure_validation_layer_support(required_validation_layers, DEBUG_MODE)
    implicit none

    ! const char *
    type(vec), intent(inout) :: required_validation_layers
    logical(c_bool), intent(in), value :: DEBUG_MODE
    ! VkLayerProperties
    type(vec) :: available_layer_array
    type(vk_layer_properties), pointer :: layer
    integer(c_int) :: available_layer_count
    logical(c_bool) :: found
    ! char **
    type(c_ptr), pointer :: raw_c_ptr_ptr
    integer(c_int) :: i, j
    character(len = :, kind = c_char), pointer :: required_layer, temp


    ! If we're not in debug mode, don't bother with this.
    if (.not. DEBUG_MODE) then
      return
    end if

    print"(A)","[Vulkan]: Checking validation layer support."

    allocate(layer)
    available_layer_array = new_vec(sizeof(layer), 0_8)

    if (vk_enumerate_instance_layer_properties(available_layer_count, c_null_ptr) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to enumerate instance layer properties."
    end if

    call available_layer_array%resize(int(available_layer_count, c_int64_t), layer)
    deallocate(layer)

    ! This is sending in the vector as if it were a C array.
    if (vk_enumerate_instance_layer_properties(available_layer_count, available_layer_array%get(1_8)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to enumerate instance layer properties."
    end if

    ! Check if we have all required validation layers when running in debug mode.
    do i = 1,int(required_validation_layers%size())

      ! From: Required validation layers.
      call c_f_pointer(required_validation_layers%get(int(i, c_int64_t)), raw_c_ptr_ptr)
      required_layer => string_from_c(raw_c_ptr_ptr)

      found = .false.

      ! Now, let's see if we have this required layer available.
      do j = 1,int(available_layer_array%size())

        call c_f_pointer(available_layer_array%get(int(j, c_int64_t)), layer)

        ! Let us convert the extension name from a char array into a string.
        temp => character_array_to_string_pointer(layer%layer_name)

        ! Check if it's what we need.
        if (required_layer == temp) then
          print"(A)","[Vulkan]: Found required validation layer ["//required_layer//"]"
          found = .true.
          deallocate(temp)
          exit
        end if

        deallocate(temp)
      end do

      ! If we're missing a required validation layer, we literally can't debug.
      if (.not. found) then
        error stop "[Vulkan] Error: Did not find required validation layer ["//required_layer//"]"
      end if
    end do

    print"(A)","[Vulkan]: Found all required validation layers."
  end subroutine ensure_validation_layer_support


end module vulkan_driver_create_validation_layers
