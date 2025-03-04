! (C) Copyright 1989- ECMWF.
! 
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation
! nor does it submit to any jurisdiction.
!

      SUBROUTINE SDICE2 (KIJS, KIJL, FL1, FLD, SL,            &
     &                   WAVNUM, CGROUP,                      &
     &                   CICV)
! ----------------------------------------------------------------------

!**** *SDICE2* - COMPUTE SEA ICE WAVE ATTENUATION FACTORS DUE TO ICE FLOES
!                BOTTOM FRICTION (CAME FROM CIWABR)


!     JEAN BIDLOT       ECMWF ~2012
!     JOSH KOUSAL       ECMWF 2023


!*    PURPOSE.
!     --------

!**   INTERFACE.
!     ----------

!       *CALL* *SDICE2 (KIJS, KIJL, FL1, FLD,SL,*
!                       WAVNUM, CGROUP,
!                       CICV)*
!          *KIJS*   - INDEX OF FIRST GRIDPOINT
!          *KIJL*   - INDEX OF LAST GRIDPOINT
!          *FL1*    - SPECTRUM.
!          *FLD*    - DIAGONAL MATRIX OF FUNCTIONAL DERIVATIVE
!          *SL*     - TOTAL SOURCE FUNCTION ARRAY
!          *WAVNUM* - WAVE NUMBER
!          *CGROUP* - GROUP SPEED
!          *CICV*   - SEA ICE COVER

!     METHOD.
!     -------

!       SEE REFERENCES.

!     EXTERNALS.
!     ----------

!       NONE.

!     REFERENCE.
!     ----------

!     KOHOUT A., M. MEYLAN, D PLEW, 2011: ANNALS OF GLACIOLOGY, 2011. 
!     M.J. Doble, J.-R. Bidlot / Ocean Modelling 70 (2013), 166-173

! ----------------------------------------------------------------------

      USE PARKIND_WAVE, ONLY : JWIM, JWRB, JWRU

      USE YOWFRED  , ONLY : DFIM
      USE YOWICE   , ONLY : CDICWA
      USE YOWPARAM , ONLY : NANG    ,NFRE
      USE YOWPCONS , ONLY : EPSMIN  

      USE YOWTEST  , ONLY : IU06

      USE YOMHOOK  , ONLY : LHOOK   ,DR_HOOK, JPHOOK

! ----------------------------------------------------------------------

      IMPLICIT NONE

      INTEGER(KIND=JWIM), INTENT(IN) :: KIJS, KIJL

      REAL(KIND=JWRB), DIMENSION(KIJL,NANG,NFRE), INTENT(IN) :: FL1
      REAL(KIND=JWRB), DIMENSION(KIJL,NANG,NFRE), INTENT(INOUT) :: FLD, SL
      REAL(KIND=JWRB), DIMENSION(KIJL,NFRE), INTENT(IN) :: WAVNUM, CGROUP
      REAL(KIND=JWRB), DIMENSION(KIJL), INTENT(IN) :: CICV

      REAL(KIND=JWRB), DIMENSION(NFRE)    :: XK2

      INTEGER(KIND=JWIM) :: IJ, K, M
      REAL(KIND=JWRB)    :: EWH
      REAL(KIND=JWRB)    :: ALP              !! ALP=SPATIAL ATTENUATION RATE OF ENERGY
      REAL(KIND=JWRB)    :: TEMP
      
      REAL(KIND=JPHOOK) :: ZHOOK_HANDLE


! ----------------------------------------------------------------------

      IF (LHOOK) CALL DR_HOOK('SDICE2',0,ZHOOK_HANDLE)

!      WRITE (IU06,*)'Ice attenuation due to bottom friction based on: '
!      WRITE (IU06,*)'  KOHOUT A., M. MEYLAN, D PLEW, 2011'

      DO M = 1,NFRE
         DO K = 1,NANG
            DO IJ = KIJS,KIJL
               EWH         = 4.0_JWRB*SQRT(MAX(EPSMIN,FL1(IJ,K,M)*DFIM(M)))
               XK2(M)      = WAVNUM(IJ,M)**2
               ALP         = CDICWA*XK2(M)*EWH
               TEMP        = -CICV(IJ)*ALP*CGROUP(IJ,M)  
               SL(IJ,K,M)  = SL(IJ,K,M)  + FL1(IJ,K,M)*TEMP
               FLD(IJ,K,M) = FLD(IJ,K,M) + TEMP
            END DO
         END DO
      END DO
      
      IF (LHOOK) CALL DR_HOOK('SDICE2',1,ZHOOK_HANDLE)

      END SUBROUTINE SDICE2
