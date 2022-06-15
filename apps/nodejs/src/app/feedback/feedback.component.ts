import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';
import { AbstractControl, FormControl, FormGroup, Validators } from '@angular/forms';
import { AccountService } from '@app/_services';

@Component({
  selector: 'app-feedback',
  templateUrl: './feedback.component.html',
  styleUrls: ['./feedback.component.scss']
})

export class FeedbackComponent implements OnInit {
  name = 'Feedback';
  title = 'SmartPharmacy Admin - Feedbacks';
  public data:any={
    email : "",
    subject : "",
    description : ""
  }
 
  
  constructor(private http: HttpClient, private accountService: AccountService ){
  }
 
  ngOnInit(){  
  }

  cancel(){
    
  }
  save(): void {
    let error = false;
    if(this.data.subject.length>80){
        error = true;
    } 
    if(this.data.description.length>400) {
      error = true;
    }
    
    if(error === false) {
    console.log(this.data);
                //add request to send email or into mysql
                this.http.post<any>("http://localhost:8095/rest/feedback/add", this.data).subscribe(
        res => {
          console.log(res);
      },
      (err: HttpErrorResponse) => {
        if (err.error instanceof Error) {
          console.log("Client-side error occured.");
        } else {
          console.log("Server-side error occurred.");
        }
      });
    }
   }
}