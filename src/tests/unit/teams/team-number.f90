! BSD 3-Clause License
!
! Copyright (c) 2016, Sourcery Institute
! All rights reserved.
!
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
!
! * Redistributions of source code must retain the above copyright notice, this
!   list of conditions and the following disclaimer.
!
! * Redistributions in binary form must reproduce the above copyright notice,
!   this list of conditions and the following disclaimer in the documentation
!   and/or other materials provided with the distribution.
!
! * Neither the name of the copyright holder nor the names of its
!   contributors may be used to endorse or promote products derived from
!   this software without specific prior written permission.
!
! THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
! AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
! IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
! DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
! FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
! DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
! SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
! CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
! OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
! OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
program main
  !! summary: Test team_number intrinsic function
  use iso_fortran_env, only : team_type
  use iso_c_binding, only : c_loc

  implicit none

  integer, parameter :: standard_initial_value=-1

  type(team_type), target :: home

  call assert(team_number()==standard_initial_value,"initial team number conforms with Fortran standard before 'change team'")

 !call assert(
 !  team_number(c_loc(home))==standard_initial_value,"initial team number conforms with Fortran standard before 'change team'"
 !)
   !! TODO: uncomment the above assertion after implementing support for team_number's optional argument:

  after_change_team: block
    associate(my_team=>mod(this_image(),2)+1)
      !! Prepare for forming two teams: my_team = 1 for even image numbers in the initial team; 2 for odd image numbers
      form team(my_team,home)
      change team(home)
        call assert(team_number()==my_team,"team number conforms with Fortran standard after 'change team'")
      end team
      call assert(team_number()==standard_initial_value,"initial team number conforms with Fortran standard")
    end associate
  end block after_change_team

  sync all
  if (this_image()==1) print *,"Test passed."

contains

  elemental subroutine assert(assertion,description)
    !! TODO: move this to a common place for all tests to use
    logical, intent(in) :: assertion
    character(len=*), intent(in) :: description
    integer, parameter :: max_digits=12
    character(len=max_digits) :: image_number
    if (.not.assertion) then
      write(image_number,*) this_image()
      error stop "Assertion " // description // "failed on image " // trim(image_number)
    end if
  end subroutine

end program
