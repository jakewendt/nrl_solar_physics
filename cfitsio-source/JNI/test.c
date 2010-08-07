#include <stdio.h>
#include <jni.h>
#include "SwingApplication.h"

JNIEXPORT void JNICALL

Java_SwingApplication_test(JNIEnv *env, jobject obj)
{
	printf ("Testing JNI\n");
	return;
}
