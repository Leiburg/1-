﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Преобразует введенные английские буквы к русской раскладке при подборе адреса
//
Процедура ПреобразоватьВводАдреса(Текст) Экспорт
	РусскиеКлавиши = "ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЁ";
	АнглийскиеКлавиши = "QWERTYUIOP[]ASDFGHJKL;'ZXCVBNM,`";
	Текст = ВРег(Текст);
	Для Позиция = 0 По СтрДлина(Текст) Цикл
		Символ = Сред(Текст, Позиция, 1);
		ПозицияСимвола = СтрНайти(АнглийскиеКлавиши, Символ);
		Если ПозицияСимвола > 0 Тогда
			Текст = СтрЗаменить(Текст, Символ, Сред(РусскиеКлавиши, ПозицияСимвола, 1));
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

Процедура ПоказатьКлассификатор(ПараметрыОткрытия, ВладелецФормы, РежимОткрытияОкна = Неопределено) Экспорт
	
	ОткрытьФорму("Справочник.СтраныМира.Форма.Классификатор", ПараметрыОткрытия, ВладелецФормы,,,,, РежимОткрытияОкна);
	
КонецПроцедуры

Процедура ОчиститьАдрес(НаселенныйПунктДетально) Экспорт
	
	Для каждого ЭлементАдреса Из НаселенныйПунктДетально Цикл
		
		Если СтрСравнить(ЭлементАдреса.Ключ, "type") = 0  Тогда
			Продолжить;
		ИначеЕсли СтрСравнить(ЭлементАдреса.Ключ, "buildings") = 0 ИЛИ СтрСравнить(ЭлементАдреса.Ключ, "apartments") = 0 Тогда
			НаселенныйПунктДетально[ЭлементАдреса.Ключ] = Новый Массив;
		Иначе
			НаселенныйПунктДетально[ЭлементАдреса.Ключ] = "";
		КонецЕсли;
		
	КонецЦикла;
	
	НаселенныйПунктДетально.addressType = РаботаСАдресамиКлиентСервер.МуниципальныйАдрес();

КонецПроцедуры

Функция ПредставлениеУровняБезСокращения(ИмяУровня) Экспорт
	
	Если СтрСравнить(ИмяУровня, "MunDistrict") = 0 
			Или СтрСравнить(ИмяУровня, "Settlement") = 0 Тогда
		Возврат Истина;
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

Функция ЭтоАдминистративноТерриториальныйАдрес(ТипАдреса) Экспорт
	Возврат СтрСравнить(ТипАдреса, РаботаСАдресамиКлиентСервер.АдминистративноТерриториальныйАдрес()) = 0;
КонецФункции

// Телефон 

// Показать подсказку корректности кода города при вводе телефона.
// 
// Параметры:
//  КодСтраны - Строка
//  КодГорода - Строка
// 
Процедура ПоказатьПодсказкуКорректностиКодовСтраныИГорода(КодСтраны, КодГорода) Экспорт
	Если (КодСтраны = "+7" ИЛИ КодСтраны = "8") И СтрНачинаетсяС(КодГорода, "9") И СтрДлина(КодГорода) <> 3 Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(НСтр("ru = 'Коды мобильных телефонов начинающиеся на цифру 9 имеют фиксированную длину в 3 цифры, например - 916.'"),, "КодГорода");
	КонецЕсли;
КонецПроцедуры

// Проверить корректность кода города и номера телефона кодов страны.
// 
// Параметры:
//  КодСтраны - Строка
//  КодГорода - Строка
//  НомерТелефона - Строка
//  СписокОшибок - СписокЗначений
// 
Процедура ПроверитьКорректностьКодовСтраныИГорода(КодСтраны, КодГорода, НомерТелефона, СписокОшибок) Экспорт
	
	Если КодСтраны = "7" ИЛИ КодСтраны = "+7" Тогда
		Если СтрДлина(УправлениеКонтактнойИнформациейКлиент.ОставитьТолькоЦифрыВСтроке(НомерТелефона)) > 7 Тогда
			СписокОшибок.Добавить("НомерТелефона", НСтр("ru = 'В России номер телефона не может быть больше 7 цифр'"));
		КонецЕсли;
	КонецЕсли;
	
	Если СтрНачинаетсяС(КодГорода, "9") И СтрДлина(КодГорода) <> 3 Тогда
		СписокОшибок.Добавить("НомерТелефона", НСтр("ru = 'В России номера мобильных телефонов должны содержать 3 цифры'"));
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти



