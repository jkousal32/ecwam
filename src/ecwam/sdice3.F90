! (C) Copyright 1989- ECMWF.
! 
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation
! nor does it submit to any jurisdiction.
!

      SUBROUTINE SDICE3 (KIJS, KIJL, FL1, FLD, SL,            &
     &                   WAVNUM, CGROUP,                      &
     &                   CICV,CITH, ALPFAC)
! ----------------------------------------------------------------------

!**** *SDICE3* - COMPUTATION OF SEA ICE ATTENUATION DUE TO VISCOUS FRICTION


!     LOTFI AOUF       METEO FRANCE 2023
!     JOSH KOUSAL      ECMWF 2023


!*    PURPOSE.
!     --------

!**   INTERFACE.
!     ----------

!       *CALL* *SDICE3 (KIJS, KIJL, FL1, FLD,SL,
!                       WAVNUM, CGROUP,                      
!                       CICV,CITH, ALPFAC)*
!          *KIJS*   - INDEX OF FIRST GRIDPOINT
!          *KIJL*   - INDEX OF LAST GRIDPOINT
!          *FL1*    - SPECTRUM.
!          *FLD*    - DIAGONAL MATRIX OF FUNCTIONAL DERIVATIVE
!          *SL*     - TOTAL SOURCE FUNCTION ARRAY
!          *WAVNUM* - WAVE NUMBER
!          *CGROUP* - GROUP SPEED
!          *CICV*   - SEA ICE COVER
!          *CITH*   - SEA ICE THICKNESS
!          *ALPFAC* - FACTOR TO REDUCE ATTENUATION IN ICE. EQUAL TO 1 IN SOLID ICE

!     METHOD.
!     -------

!       SEE REFERENCES.

!     EXTERNALS.
!     ----------

!       NONE.

!     REFERENCE.
!     ----------

!     Jie Yu * , W. Erick Rogers, David W. Wang, 2022 
!     DOI:10.1016/j.coldregions.2022.103582

! ----------------------------------------------------------------------

      USE PARKIND_WAVE, ONLY : JWIM, JWRB, JWRU

      USE YOWFRED  , ONLY : FR      
      USE YOWPARAM , ONLY : NANG    ,NFRE
      USE YOWPCONS , ONLY : G       ,ZPI

      USE YOWTEST  , ONLY : IU06

      USE YOMHOOK  , ONLY : LHOOK   ,DR_HOOK, JPHOOK

! ----------------------------------------------------------------------

      IMPLICIT NONE

      INTEGER(KIND=JWIM), INTENT(IN) :: KIJS, KIJL

      REAL(KIND=JWRB), DIMENSION(KIJL,NANG,NFRE), INTENT(IN) :: FL1
      REAL(KIND=JWRB), DIMENSION(KIJL,NANG,NFRE), INTENT(INOUT) :: FLD, SL
      REAL(KIND=JWRB), DIMENSION(KIJL,NFRE), INTENT(IN) :: WAVNUM, CGROUP
      REAL(KIND=JWRB), DIMENSION(KIJL), INTENT(IN) :: CICV
      REAL(KIND=JWRB), DIMENSION(KIJL), INTENT(IN) :: CITH
      REAL(KIND=JWRB), DIMENSION(KIJL), INTENT(IN) :: ALPFAC

      REAL(KIND=JWRB), DIMENSION(KIJL,NFRE)        :: ALP  !! ALP=SPATIAL ATTENUATION RATE OF ENERGY
      
      INTEGER(KIND=JWIM) :: IMODEL                              !! DAMPING MODEL: 1=FIT TO TEMPELFJORD DATA, 2=Jie Yu 2022
      INTEGER(KIND=JWIM) :: IJ, K, M
      REAL(KIND=JWRB)    :: TEMP
      REAL(KIND=JWRB)    :: CDICE
      REAL(KIND=JWRB)    :: HICEMAX, HICEMIN
      
      REAL(KIND=JPHOOK) :: ZHOOK_HANDLE


! ----------------------------------------------------------------------

      IF (LHOOK) CALL DR_HOOK('SDICE3',0,ZHOOK_HANDLE)

      IMODEL = 2
!      IF (ITEST.GE.2) WRITE (IU06,*)'IMODEL =',IMODEL
      HICEMAX=4.0_JWRB
      HICEMIN=0.1_JWRB
   
!     WRITE (IU06,*)'Ice attenuation due to viscous friction based on: '
      
      SELECT CASE (IMODEL)
         CASE (1)
!          WRITE (IU06,*)'  Best fit w Tempelfjorde obs from Lotfi Aouf'
           CDICE=0.0656_JWRB

           DO M = 1,NFRE
             DO IJ = KIJS,KIJL
                ALP(IJ,M) = (CDICE*CITH(IJ)*WAVNUM(IJ,M)**2) * ALPFAC(IJ)    
             END DO
           END DO

         CASE (2)
!          WRITE (IU06,*)'  Jie Yu, W. Erik Rogers, David W. Wang 2022'
           CDICE=0.1274_JWRB*( ZPI/SQRT(G) )**(4.5_JWRB)
         
           DO M = 1,NFRE
              DO IJ = KIJS,KIJL
                 ALP(IJ,M) = (2._JWRB*CDICE*(CITH(IJ)**(1.25_JWRB))*(FR(M)**(4.5_JWRB))) * ALPFAC(IJ)
              END DO
           END DO
         
      END SELECT

      DO M = 1,NFRE
         DO K = 1,NANG
            DO IJ = KIJS,KIJL
               TEMP        = -CICV(IJ)*ALP(IJ,M)*CGROUP(IJ,M)         
               SL(IJ,K,M)  = SL(IJ,K,M)  + FL1(IJ,K,M)*TEMP
               FLD(IJ,K,M) = FLD(IJ,K,M) + TEMP
            END DO
         END DO
      END DO
      
      IF (LHOOK) CALL DR_HOOK('SDICE3',1,ZHOOK_HANDLE)

      END SUBROUTINE SDICE3
