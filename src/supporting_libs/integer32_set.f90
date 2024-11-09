module integer32_set
  use, intrinsic :: iso_c_binding
  implicit none

  ! A very smol unoptimized std::set<int32_t> library.

  type :: int32_set
    integer(c_int32_t), dimension(:), pointer :: data => null()

  contains

  end type int32_set

end module integer32_set
