package com.app.workit.data.repository;

import android.net.Uri;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.Continuation;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;
import com.app.workit.data.network.APIService;
import com.app.workit.data.network.NetworkResponse;

import javax.inject.Inject;

import io.reactivex.subjects.BehaviorSubject;

public class UploadImageRepository {

    private final StorageReference storageReference;
    private APIService apiService;
    private BehaviorSubject<NetworkResponse<String>> uploadSubject = BehaviorSubject.create();

    @Inject
    public UploadImageRepository(APIService apiService, FirebaseStorage firebaseStorage) {
        this.apiService = apiService;
        // Create a storage reference from our app
        storageReference = firebaseStorage.getReference();
    }

    public BehaviorSubject<NetworkResponse<String>> getUploadSubject() {
        return uploadSubject;
    }

    public void uploadImage(Uri imageUri, String childPath) {
        // Create a child reference
        String fullPath = childPath + '/' + imageUri.getLastPathSegment();
        StorageReference imagesRef = storageReference.child(fullPath);

        UploadTask uploadTask = imagesRef.putFile(imageUri);
        uploadSubject.onNext(NetworkResponse.loading());

        uploadTask.addOnSuccessListener(new OnSuccessListener<UploadTask.TaskSnapshot>() {
            @Override
            public void onSuccess(UploadTask.TaskSnapshot taskSnapshot) {

            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {

            }
        });

        Task<Uri> urlTask = uploadTask.continueWithTask(new Continuation<UploadTask.TaskSnapshot, Task<Uri>>() {
            @Override
            public Task<Uri> then(@NonNull Task<UploadTask.TaskSnapshot> task) throws Exception {
                if (!task.isSuccessful()) {
                    throw task.getException();
                }

                // Continue with the task to get the download URL
                return imagesRef.getDownloadUrl();
            }
        }).addOnCompleteListener(new OnCompleteListener<Uri>() {
            @Override
            public void onComplete(@NonNull Task<Uri> task) {
                if (task.isSuccessful()) {
                    Uri downloadUri = task.getResult();

                    uploadSubject.onNext(NetworkResponse.success(downloadUri.toString(), ""));
                } else {
                    // Handle failures
                    // ...
                    uploadSubject.onNext(NetworkResponse.error(task.getException().getMessage()));
                }
            }
        });

    }


}
