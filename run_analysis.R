############### DOWNLOAD FILES
if(!file.exists("./data"))
{dir.create("./data")}
fileurl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
filepath <- file.path(getwd(), "dataset.zip")
download.file(fileurl,filepath)

############### UNZIP
unzip(zipfile="./data/dataset.zip",exdir="./data")
###############
path_UCI<-file.path("./data","UCI HAR Dataset")
UCI_files<-list.files(path_UCI,recursive=TRUE)
UCI_files

################ read activity files
activity_test<-read.table(file.path(path_UCI,"test","Y_test.txt"),header=FALSE)
activity_train<-read.table(file.path(path_UCI,"train","Y_train.txt"),header=FALSE)

################read subject files
subject_test<-read.table(file.path(path_UCI,"test","subject_test.txt"),header=FALSE)
subject_train<-read.table(file.path(path_UCI,"train","subject_train.txt"),header=FALSE)

################ read features files
features_test<-read.table(file.path(path_UCI,"test","X_test.txt"),header=FALSE)
features_train<-read.table(file.path(path_UCI,"train","X_train.txt"),header=FALSE)

###########################preview
str(activity_test)
str(activity_train)
str(subject_test)
str(subject_train)
str(features_test)
str(features_train)

############# merges training and test sets and create single set by concatenating data tables
subject<-rbind(subject_train,subject_test)
activity<-rbind(activity_train,activity_test)
features<-rbind(features_train,features_test)

######################## set names to variable
names(subject)<-c("subject")
names(activity)<-c("activity")
features_names<-read.table(file.path(path_UCI,"features.txt"),head=FALSE)

################

names(features)<-features_names$V2
names(features)<-gsub("-","_",as.character(features_names$V2))
names(features)<-gsub("()", "",cleanfeaturenames,fixed=TRUE)

############################################### read activity labels file
activity_labels<-read.table(file.path(path_UCI,"activity_labels.txt"),header=FALSE)
colnames(activity_labels)<-c("Id_Activity","activity")
colnames(data)<-c("Id_subject","Id_Activity",names_selected)

merge_labels<-rbind(activity_test,activity_train)
colnames(merge_labels)[1]<-"Id_Activity"
merge_activity<-merge(merge_labels,activity_labels,by="Id_Activity")

######################################## merge columsn and get data frame for all datas
datamerge <-cbind(subject,merge_activity)
data<-cbind(features,datamerge)

####################################### create subset by selected names of the features subject, activity
subsetfeaturenames<-features_names$V2[grep("mean\\(\\)|std\\(\\)",features_names$V2)]
names_selected<-c(as.character(subsetfeaturenames),"subject","activity")
names_selected<-gsub("-", "",names_selected,fixed=TRUE)
names_selected<-gsub("()", "",names_selected,fixed=TRUE)


##################################  properly set names for labels the data set 
names(data)<-gsub("^t","time",names(data))
names(data)<-gsub("^f","frequency",names(data))
names(data)<-gsub("^Acc","Accelerometer",names(data))
names(data)<-gsub("^Gyro","Gyroscope",names(data))
names(data)<-gsub("^Mag","Magnitude",names(data))
names(data)<-gsub("^BodyBody","Body",names(data))


#####################  create tidy data set
library(plyr);

data_tidy<-aggregate(. ~activity + subject, data, mean)
data_tidy<-data_tidy[order(data_tidy$activity,data_tidy$subject),]

############give descriptive names
# data_tidy<-merge(activity_labels,data_tidy,by="Id_Activity")
colnames(data_tidy)<-c("activity","subject",cleanfeaturenames)


write.table(data_tidy,file="tidydata.txt",row.name=FALSE)

#####################