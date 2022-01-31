﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Возвращает ежегодное расписание для события на указанную дату.
//
// Параметры:
//  ДатаСобытия - Дата - произвольная дата.
//
// Возвращаемое значение:
//  РасписаниеРегламентногоЗадания - расписание.
//
Функция ЕжегодноеРасписание(ДатаСобытия) Экспорт
	Месяцы = Новый Массив;
	Месяцы.Добавить(Месяц(ДатаСобытия));
	ДеньВМесяце = День(ДатаСобытия);
	
	Расписание = Новый РасписаниеРегламентногоЗадания;
	Расписание.ПериодПовтораДней = 1;
	Расписание.ПериодНедель = 1;
	Расписание.Месяцы = Месяцы;
	Расписание.ДеньВМесяце = ДеньВМесяце;
	Расписание.ВремяНачала = '000101010000' + (ДатаСобытия - НачалоДня(ДатаСобытия));
	
	Возврат Расписание;
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Возвращает структуру напоминания с заполненными значениями.
//
// Параметры:
//  ДанныеДляЗаполнения - Структура - значения для заполнения параметров напоминания.
//  ВсеРеквизиты - Булево - если истина, то возвращает также реквизиты, связанные с настройкой
//                          времени напоминания.
//
Функция ОписаниеНапоминания(ДанныеДляЗаполнения = Неопределено, ВсеРеквизиты = Ложь) Экспорт
	Результат = Новый Структура("Пользователь,ВремяСобытия,Источник,СрокНапоминания,Описание,Идентификатор");
	Если ВсеРеквизиты Тогда 
		Результат.Вставить("СпособУстановкиВремениНапоминания");
		Результат.Вставить("ИнтервалВремениНапоминания", 0);
		Результат.Вставить("ИмяРеквизитаИсточника");
		Результат.Вставить("Расписание");
		Результат.Вставить("ИндексКартинки", 2);
		Результат.Вставить("ПовторятьЕжегодно", Ложь);
	КонецЕсли;
	Если ДанныеДляЗаполнения <> Неопределено Тогда
		ЗаполнитьЗначенияСвойств(Результат, ДанныеДляЗаполнения);
	КонецЕсли;
	Возврат Результат;
КонецФункции

#КонецОбласти
