program strided_get
  implicit none

  integer :: i,me,np
  integer,allocatable :: a(:,:,:,:)[:],b(:,:,:,:)
  complex(kind=DPC),allocatable :: ac(:,:,:,:)[:],bc(:,:,:,:)

  me = this_image()
  np = num_images()

  allocate(ac(0:11,-10:-5,-1:0,-1:5)[*],bc(6,6,2,7))

  ac = me
  bc = me

  sync all

  if(me == 2) then
    bc(1:2,:,:,:) = ac(0:1,:,:,:)[me-1]
    if(any(bc(1:2,:,:,:) /= 1)) call abort()
    write(*,*) 'Test passed.'
  endif

end program
