diff --git a/AmberTools/src/cpptraj/test/Test_XYZformat/RunTest.sh b/AmberTools/src/cpptraj/test/Test_XYZformat/RunTest.sh
index e109c9b1..e99f4ed5 100755
--- a/AmberTools/src/cpptraj/test/Test_XYZformat/RunTest.sh
+++ b/AmberTools/src/cpptraj/test/Test_XYZformat/RunTest.sh
@@ -34,11 +34,11 @@ UNITNAME='Atom XYZ format read'
 N=1
 for FILE in tz2.xyz tz2.st.xyz tz2.nt.at.xyz tz2.nt.xyz tz2.mt.at.xyz tz2.mt.xyz ; do
   if [ $N -eq 6 ] ; then
-    AS='as xyz'
+    ASXYZ='as xyz'
   fi
   cat > xyz.in <<EOF
 parm ../tz2.parm7
-trajin $FILE $AS
+trajin $FILE $ASXYZ
 trajout test$N.crd
 EOF
   RunCpptraj "$UNITNAME, test $N"
